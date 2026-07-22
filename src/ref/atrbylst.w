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

$Revision: 2de6324c153c, 2832, rls $
$Author: EShklyar $
$Date: Пн ноя 22 19:48:51 2021 +0300 $
$Workfile: atrbylst.w $
$Archive: ref/atrbylst.w $

Механизм простановки атрибутов на различные сущности - gds-obj-attr gds-host-attr cli-attr

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
/*на какой таблице работаем - может быть gds-obj-attr gds-host-attr {&table_clients-attr} goods-attr*/
define input parameter parhost-code like ub.sysconf.host-code no-undo.
/*текущая фирма*/
define input parameter parobj-type like ub.clients.obj-type no-undo.
/*текущий объект*/
define input parameter parobj-code like ub.clients.obj-code no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision: 2de6324c153c, 2832, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Пн ноя 22 19:48:51 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: atrbylst.w $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/atrbylst.w $":U .
define variable vss-description as character no-undo init "Атрибуты товара на объекте ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ cmp/cli-list.i cli-list def "new shared" }
{ cmp/dc-list.i dc-list def "new shared" }
{ cmp/gds-list.i gds-list def "new shared" }
{ cmp/bitoper.i }
{ cmp/tempattr.i "NEW SHARED" par-subject parhost-code paobj-type parobj-code }
{ gbl/clntattr.i interface parparentproc }
{ gbl/getcntxt.i def }
{ gbl/userobjs.i }
{ ref/gds-attr.i interface parparentproc }
{ ref/gdshattr.i interface paraprentproc }
{ ref/gdsoattr.i interface parparentproc }
{ ref/attr-pop.i def }
{ ref/attr-pop.i proc }
{ cmp/obj-list.i NEW }
&scoped-define  tempattr-type-get-error message "Ошибка при определении названия и типа атрибута !" ~
        "Обратитесь к администратору системы" skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.
&scoped-define  tempattr-value-get-error message "Ошибка при определении значения атрибута !" ~
        "Обратитесь к администратору системы" skip error-status:get-message(1) skip ~
        return-value skip view-as alert-box ERROR.

define variable add-option   as char    no-undo.
DEFINE VARIABLE add-host     like ub.sysconf.host-code no-undo .
DEFINE VARIABLE add-obj-type like ub.clients.obj-type no-undo .
DEFINE VARIABLE add-obj-code like ub.clients.obj-code no-undo .
define variable updated      as logical no-undo.
define variable temp-doc-rec as recid   no-undo.
define buffer del_temp-attr for temp-attr.
define variable glog        as logical   no-undo .
define variable glog-obj    as logical   no-undo .
define variable v-tab-order AS character no-undo.

DEFINE MENU menu-b-add.
DEFINE MENU menu-b-add-2.

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
&Scoped-define INTERNAL-TABLES temp-attr del_temp-attr

/* Definitions for BROWSE BR-add                                        */
&Scoped-define FIELDS-IN-QUERY-BR-add temp-attr.code temp-attr.attr-value
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-add
&Scoped-define SELF-NAME BR-add
&Scoped-define QUERY-STRING-BR-add FOR EACH temp-attr where temp-attr.action = yes NO-LOCK
&Scoped-define OPEN-QUERY-BR-add OPEN QUERY {&SELF-NAME} FOR EACH temp-attr where temp-attr.action = yes NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-add temp-attr
&Scoped-define FIRST-TABLE-IN-QUERY-BR-add temp-attr


/* Definitions for BROWSE BR-del                                        */
&Scoped-define FIELDS-IN-QUERY-BR-del del_temp-attr.code
&Scoped-define ENABLED-FIELDS-IN-QUERY-BR-del
&Scoped-define SELF-NAME BR-del
&Scoped-define QUERY-STRING-BR-del FOR EACH del_temp-attr where del_temp-attr.action = no NO-LOCK
&Scoped-define OPEN-QUERY-BR-del OPEN QUERY {&SELF-NAME} FOR EACH del_temp-attr where del_temp-attr.action = no NO-LOCK.
&Scoped-define TABLES-IN-QUERY-BR-del del_temp-attr
&Scoped-define FIRST-TABLE-IN-QUERY-BR-del del_temp-attr


/* Definitions for DIALOG-BOX Dialog-Frame                              */
&Scoped-define OPEN-BROWSERS-IN-QUERY-Dialog-Frame ~
    ~{&OPEN-QUERY-BR-add}~
    ~{&OPEN-QUERY-BR-del}

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit b-quit B-list B-list-obj B-Help ~
T-delete-ok b-add B-chg B-del BR-add b-add-2 B-del-2 E-obj BR-del ~
F-obj-name
&Scoped-Define DISPLAYED-OBJECTS T-delete-ok E-obj F-obj-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-add
   LABEL "&Добавить":L
   SIZE 10 BY 1 TOOLTIP "Выбрать атрибут для добавления".

DEFINE BUTTON b-add-2
   LABEL "&Добавить":L
   SIZE 10 BY 1 TOOLTIP "Выбрать атрибут для удаления".

DEFINE BUTTON B-chg
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
   SIZE 10 BY 1 TOOLTIP "Установить/изменить/удалить атрибуты по списку"
   BGCOLOR 8 .

DEFINE BUTTON B-Help
   LABEL "Помо&щь"
   SIZE 3 BY 1
   BGCOLOR 8 .

DEFINE BUTTON B-list
   LABEL "&Список товаров"
   SIZE 20 BY 1 TOOLTIP "Создание списка".

DEFINE BUTTON B-list-obj
   LABEL "Список о&бъектов"
   SIZE 20 BY 1 TOOLTIP "Создание списка объектов".

DEFINE BUTTON b-quit AUTO-END-KEY
   LABEL "&Отмена"
   SIZE 10 BY 1
   BGCOLOR 8 .

DEFINE VARIABLE E-obj       AS CHARACTER
   VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL
   SIZE 29 BY 8.13 NO-UNDO.

DEFINE VARIABLE F-obj-name  AS CHARACTER FORMAT "X(256)":U
   VIEW-AS TEXT
   SIZE 52.5 BY .67
   FGCOLOR 4 NO-UNDO.

DEFINE VARIABLE T-delete-ok AS LOGICAL   INITIAL no
   LABEL "Удалять записи списка в случае удачного изменения"
   VIEW-AS TOGGLE-BOX
   SIZE 52 BY 1 NO-UNDO.

/* Query definitions                                                    */
&ANALYZE-SUSPEND
DEFINE QUERY BR-add FOR
   temp-attr SCROLLING.

DEFINE QUERY BR-del FOR
   del_temp-attr SCROLLING.
&ANALYZE-RESUME

/* Browse definitions                                                   */
DEFINE BROWSE BR-add
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-add Dialog-Frame _FREEFORM
   QUERY BR-add DISPLAY
   temp-attr.code column-label "Атрибут"  format "X(50)"
   temp-attr.attr-value column-label "Значение"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 84 BY 8
         TITLE "Будут добавлены/изменены атрибуты".

DEFINE BROWSE BR-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _DISPLAY-FIELDS BR-del Dialog-Frame _FREEFORM
   QUERY BR-del DISPLAY
   del_temp-attr.code  column-label "Атрибут" format "X(50)"
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME
    WITH NO-ROW-MARKERS SEPARATORS SIZE 53 BY 8
         TITLE "Будут удалены атрибуты".


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
   B-exit AT ROW 1 COL 1
   b-quit AT ROW 1 COL 11
   B-list AT ROW 1 COL 31
   B-list-obj AT ROW 1 COL 51 WIDGET-ID 2
   B-Help AT ROW 1 COL 71
   T-delete-ok AT ROW 3.5 COL 1.5
   b-add AT ROW 4.77 COL 1
   B-chg AT ROW 4.77 COL 11
   B-del AT ROW 4.77 COL 21
   BR-add AT ROW 5.77 COL 1
   b-add-2 AT ROW 14 COL 1
   B-del-2 AT ROW 14 COL 11
   E-obj AT ROW 14.87 COL 55 NO-LABEL WIDGET-ID 4
   BR-del AT ROW 15 COL 1
   F-obj-name AT ROW 2.27 COL 30 COLON-ALIGNED NO-LABEL
   SPACE(0.50) SKIP(20.06)
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
/* BROWSE-TAB BR-del E-obj Dialog-Frame */
ASSIGN
   FRAME Dialog-Frame:SCROLLABLE = FALSE
   FRAME Dialog-Frame:HIDDEN     = TRUE.

ASSIGN
   E-obj:READ-ONLY IN FRAME Dialog-Frame = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-add
/* Query rebuild information for BROWSE BR-add
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH temp-attr where temp-attr.action = yes NO-LOCK.
     _END_FREEFORM
     _Query            is OPENED
*/  /* BROWSE BR-add */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _QUERY-BLOCK BROWSE BR-del
/* Query rebuild information for BROWSE BR-del
     _START_FREEFORM
OPEN QUERY {&SELF-NAME} FOR EACH del_temp-attr where del_temp-attr.action = no NO-LOCK.
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
      run proc-b-add in this-procedure ( input par-subject) no-error .
      if error-status:error then return no-apply.
   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-add-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-add-2 Dialog-Frame
ON CHOOSE OF b-add-2 IN FRAME Dialog-Frame /* Добавить */
   DO:
      run proc-b-add-2 in this-procedure ( input par-subject) no-error .
      if error-status:error then return no-apply.
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


&Scoped-define SELF-NAME B-del
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-del Dialog-Frame
ON CHOOSE OF B-del IN FRAME Dialog-Frame /* Удалить */
   DO:
      define variable loc#log as logical no-undo.
      if not avail temp-attr then return no-apply.
      loc#log = no.
      message "Вы уверены, что хотите удалить атрибут"  "<" temp-attr.code ">" skip
         "из списка атрибутов подлежащих установке/изменению?"  skip
         view-as alert-box QUESTIOn buttons YES-NO update loc#log.
      if NOT loc#log then return no-apply.
      run tempattr-delete in this-procedure (
         input temp-attr.attr-code
         ,input temp-attr.host-code
         ,input temp-attr.obj-type
         ,input temp-attr.obj-code
         ,output loc#log) no-error .
      if error-status:error or not loc#log then 
      do:
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
      if not avail del_temp-attr then return no-apply.
      loc#log = no.
      message "Вы уверены, что хотите удалить атрибут" "<" del_temp-attr.code ">" skip
         "из списка атрибутов, подлежащих удалению?" skip
         view-as alert-box QUESTIOn buttons YES-NO update loc#log.
      if NOT loc#log then return no-apply.
      run tempattr-delete in this-procedure (
         input del_temp-attr.attr-code
         ,input del_temp-attr.host-code
         ,input del_temp-attr.obj-type
         ,input del_temp-attr.obj-code
         ,output loc#log) no-error .
      if error-status:error or not loc#log then 
      do:
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
      CASE par-subject:
         when {&table_gds-obj-attr}
         or
         when {&table_gds-host-attr}
         or
         when {&table_goods-attr}
         then 
            do:
               run str/gds-list.w ( input parparentproc, input parhost-code, input parobj-type, input parobj-code).
               b-list:label = "&Список товаров".
            end.
         when {&table_clients-attr} then 
            do:
               run str/cli-list.w ( input parparentproc, parhost-code, parobj-type, parobj-code).
               b-list:label = "Список клиентов".
            end.
      END CASE.

   END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-list-obj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-list-obj Dialog-Frame
ON CHOOSE OF B-list-obj IN FRAME Dialog-Frame /* Список объектов */
   DO:
      DEFINE buffer buf_clients for ub.clients  .
      define buffer buf_sysconf for ub.sysconf  .
      define variable v-list      as character no-undo .
      define variable v-host-code as integer   no-undo .
      define variable v-num       as integer   no-undo .
      define variable ii          as integer   no-undo .
      define variable v-rid       as recid     no-undo .
      define variable v-ii        as integer   no-undo .
      assign t-delete-ok.
      CASE par-subject:
         when {&table_gds-obj-attr} THEN 
            DO:
               for each obj-list :
                  delete obj-list.
               end.
               if v-cntxt-db-num = 0 then 
               do:
                  run ref/thobjs.w
                     ( input parparentproc
                     , input this-procedure:handle
                     , input "b-mark,b-sel"
                     , input {&all}
                     , input '' /*p-obj-type*/
                     , input ? /*p-db-num*/
                     , input ? /*p-host-code*/
                     , input-output v-list ) no-error .

               end.
               else 
               do:
                  run ref/thobjs.w
                     ( input parparentproc
                     , input this-procedure:handle
                     , input "b-mark,b-sel"
                     , input {&all}
                     , input '' /*p-obj-type*/
                     , input v-cntxt-db-num /*p-db-num*/
                     , input ? /*p-host-code*/
                     , input-output v-list ) no-error .
               end.
               assign
                  e-obj:screen-value = ''.
               for each obj-list:
                  delete obj-list.
               end.
               define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj.
               for each buf_userobjs_temp-user-obj:
                  run create_obj-list ( buf_userobjs_temp-user-obj.obj-type, buf_userobjs_temp-user-obj.obj-code) .
                  v-ii = v-ii + 1.
                  e-obj:screen-value in frame {&frame-name} = e-obj:screen-value in frame {&frame-name} +
                     (if e-obj:screen-value = '' then '' else {&new-line}) +
                     buf_userobjs_temp-user-obj.obj-type + string(buf_userobjs_temp-user-obj.obj-code).
               end.
            END. /*when {&table_gds-obj-attr} THEN DO:*/
         when {&table_gds-host-attr} then 
            do:
               for each obj-list:
                  find first buf_sysconf no-lock where
                     buf_sysconf.host-code = obj-list.obj-code no-error.
                  if available buf_sysconf then 
                  do:
                     assign
                        v-list = v-list + (if v-list = '' then '' else {&comma-char}) +  string(recid(buf_sysconf)).
                  end.
               end.
               run adm/sconfs.w (
                  input  parparentproc
                  ,input  'b-sel,b-mark':U
                  ,input  no
                  ,input  v-cntxt-host-code-obj
                  ,output v-host-code
                  ,input-output v-list
                  ) .
               if v-list = "" then return no-apply .
               assign 
                  v-num = num-entries (v-list) .
               do ii = 1 to v-num :
                  find first buf_sysconf no-lock where RECID(buf_sysconf) = integer(entry(ii, v-list)) no-error.
                  find first obj-list where
                     obj-list.obj-type = {&cmp}
                     and obj-list.obj-code = buf_sysconf.host-code no-error.
                  if not available obj-list then 
                  do:
                     run create_obj-list ( input {&cmp}, input buf_sysconf.host-code) .
                  end.
               end.
               assign
                  e-obj:screen-value = ''.
               for each obj-list:
                  v-ii = v-ii + 1.
                  e-obj:screen-value in frame {&frame-name} = e-obj:screen-value in frame {&frame-name} +
                     (if e-obj:screen-value = '' then '' else {&new-line}) +
                     obj-list.obj-type + string(obj-list.obj-code).
               end.
            end.
      END CASE.
      if v-ii > 1 then 
      do:
         assign
            t-delete-ok = no.
         display
            t-delete-ok
            with frame {&frame-name} .
         disable
            t-delete-ok
            with frame {&frame-name} .
         case par-subject:
            when {&table_gds-obj-attr} then 
               do:
                  find first tt-attr-property where
                     tt-attr-property.table-name = {&table_gds-obj-attr}
                     and tt-attr-property.attr-code = {&attr-proprietor-o} no-error.
                  if available tt-attr-property then 
                  do:
                     assign
                        tt-attr-property.menu-item-handle:sensitive = no
                        .
                  end.
                  define buffer buf_temp-attr for temp-attr.
                  for each buf_temp-attr where
                     buf_temp-attr.attr-code = {&attr-proprietor-o} :
                     message
                        substitute("Нельзя устанавливать атрибут &1 для списка объектов, если объектов в списке больше 1&1Удаляю..."
                        , buf_temp-attr.code)
                        view-as alert-box error .
                     delete buf_temp-attr.
                  end.
                  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
               end.
         end case.
      end.
      else 
      do:
         case par-subject:
            when {&table_gds-obj-attr} then 
               do:
                  define variable v-is-tpsi-object as logical no-undo .
                  run gbl/tpsi-obj.p (
                     input parobj-type
                     ,input parobj-code
                     ,output v-is-tpsi-object
                     ) no-error .
                  find first tt-attr-property where
                     tt-attr-property.table-name = {&table_gds-obj-attr}
                     and tt-attr-property.attr-code = {&attr-proprietor-o} no-error.
                  if available tt-attr-property then 
                  do:
                     assign
                        tt-attr-property.menu-item-handle:sensitive = v-is-tpsi-object
                        .
                  end.
               end.
         end case.
         display
            t-delete-ok
            with frame {&frame-name} .
         enable
            t-delete-ok
            with frame {&frame-name} .
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
   if lookup(par-subject, ({&table_gds-obj-attr} + {&comma-char} +
      {&table_gds-host-attr} + {&comma-char} +
      {&table_clients-attr} + {&comma-char} +
      {&table_goods-attr})) = 0 then 
   do:

      message
         vss-workfile vss-revision vss-description skip
         "Неверное значение параметра par-subject" par-subject
         view-as alert-box error.
      return error.
   end.

   CASE par-subject:
      when {&table_gds-obj-attr}
      then do:
     { gbl/chk-actg.i
          v-cntxt-db-num
          v-cntxt-userid
          {&action-head-code-main}
          'actn_reference_update_dopinfo':U
          {&cntxt-object}
          v-cntxt-host-code-obj
          v-cntxt-obj-type
          v-cntxt-obj-code
          0
          0
          0
          false
          glog-obj
        }
     if glog-obj then 
     do:
       { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_reference_update':U
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      false
      glog
      }
     end.
     else 
     do:
       { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_reference_update':U
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      true
      glog
      }
       if not glog then 
       do:
         return.
       end.   
     end.
     
      end.
      when {&table_gds-host-attr}
      or
      when {&table_goods-attr}
      then 
         do:
            { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_reference_update':U
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      true
      glog
      }
            if not glog then 
            do:
               return.
            end.
         end.
      when {&table_clients-attr} then 
         do:
            { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_client-reference_update':U
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      true
      glog
      }

            if not glog then 
            do:
               return.
            end.
         end.
   END CASE.
   find first X_clients-obj no-lock where
      X_clients-obj.obj-type = parobj-type AND
      X_clients-obj.obj-code = parobj-code no-error .
   if not avail X_clients-obj then 
   do:
      message vss-workfile vss-revision vss-description skip
         "Неверное значение параметра parobj-type и/или parobj-code" parobj-type parobj-code
         view-as alert-box error.
      return error.
   end.
   { ref/attr-pop.i prepare }
   RUN enable_UI in this-procedure .
   RUN MYenable in this-procedure .
   WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI in this-procedure .
run attr-pop-clean-up in this-procedure ( input par-subject ).

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE choose-to-add Dialog-Frame
PROCEDURE choose-to-add :
   define input parameter p-attr-code as character no-undo .
    if p-attr-code <> "min-zapas" then do:
            { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_reference_update':U
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      true
      glog
      }
    if not glog then return error .
    end.
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
    if p-attr-code <> "min-zapas" then do:
            { gbl/chk-actg.i
      v-cntxt-db-num
      v-cntxt-userid
      {&action-head-code-main}
      'actn_reference_update':U
      {&cntxt-global}
      0
      '':U
      0
      0
      0
      0
      true
      glog
      }
    if not glog then return error .
    end.
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
   DISPLAY T-delete-ok E-obj F-obj-name
      WITH FRAME Dialog-Frame.
   ENABLE B-exit b-quit B-list B-list-obj B-Help T-delete-ok b-add B-chg B-del
      BR-add b-add-2 B-del-2 E-obj BR-del F-obj-name
      WITH FRAME Dialog-Frame.
   VIEW FRAME Dialog-Frame.
   {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame
PROCEDURE init-proc :
   /*------------------------------------------------------------------------------
     Purpose:
     Parameters:  <none>
     Notes:
   ------------------------------------------------------------------------------*/
   define var attr-type           as character no-undo .          /* тип атрибута      */
   define var attr-format         as character no-undo .        /* формат атрибута   */
   define var attr-label          as character no-undo .         /* лабел атрибута    */
   define var attr-value          as character no-undo .         /* значение атрибута */
   define var attr-user-can-edit  as logical   no-undo .   /* пользователь может изменять в броусе */
   define var attr-output-display as logical   no-undo .  /* виден в броусе    */
   define var attr-other          as char      no-undo .              /* еще чего - нибудь */
   assign
      add-option   = ""
      add-host     = 0
      add-obj-type = "":U
      add-obj-code = 0
      .
   {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE MyEnable Dialog-Frame
PROCEDURE MyEnable :
   define variable v-edit-proc-name     as character no-undo .
   define variable v-tooltip-proc-name  as character no-undo .
   define variable v-attr-list-pre-name as character no-undo .
   define variable alco-val             as character no-undo .
   define variable alco-type            as character no-undo .
   define variable alco-val-log         as logical   no-undo .
   assign
      b-add:MENU-MOUSE in frame {&frame-name}   = 1
      b-add-2:MENU-MOUSE in frame {&frame-name} = 1
      b-add:POPUP-MENU IN FRAME {&frame-name}   = MENU MENU-b-add:HANDLE.
   b-add-2:POPUP-MENU IN FRAME {&frame-name} = MENU MENU-b-add-2:HANDLE.
   .

   CASE par-subject:
      when {&table_goods-attr} then 
         do:
            assign
               v-edit-proc-name     = 'gds-attr-batch-edit'
               v-tooltip-proc-name  = 'gds-attr-tooltip'
               v-attr-list-pre-name = {&gds-attr-list}
               .
         end.
      when {&table_gds-obj-attr} then 
         do:
            run userobjs_append in this-procedure ( input parobj-type
               ,input parobj-code).
            assign
               v-edit-proc-name     = 'gdsoattr-batch-edit'
               v-tooltip-proc-name  = 'gdsoattr-tooltip'
               v-attr-list-pre-name = {&gdsoattr-list}
               .
         end.
      when {&table_gds-host-attr} then 
         do:
            run create_obj-list ( input {&cmp}, input parhost-code) .
            assign
               v-edit-proc-name     = 'gdshattr-batch-edit'
               v-tooltip-proc-name  = 'gdshattr-tooltip'
               v-attr-list-pre-name = {&gdshattr-list}
               .

         end.
      when {&table_clients-attr} then 
         do:
            assign
               v-edit-proc-name     = 'clntattr-batch-edit'
               v-tooltip-proc-name  = 'clntattr-tooltip'
               v-attr-list-pre-name = {&clntattr-list}
               .
         end.
   END CASE.

   run attr-pop-create-items in this-procedure  (
      input par-subject
      ,input v-edit-proc-name  /*p-get-section-num-proc-name*/
      ,input v-tooltip-proc-name
      ,input 'choose-to-add'
      ,input menu menu-b-add:handle
      ,input v-attr-list-pre-name
      ).

   run attr-pop-create-items in this-procedure  (
      input par-subject
      ,input v-edit-proc-name  /*p-get-section-num-proc-name*/
      ,input v-tooltip-proc-name
      ,input 'choose-to-delete'
      ,input menu menu-b-add-2:handle
      ,input v-attr-list-pre-name
      ).

   CASE par-subject:
      when {&table_clients-attr} then 
         do:
            disable
               b-list-obj
               with frame {&frame-name} .

         end.
      when {&table_goods-attr} then 
         do:
            disable
               b-list-obj
               with frame {&frame-name} .
            { gbl/conf-rd.i
          "'alcohol'"
          "''"
          "''"
          0
          "''"
          "''"
          "''"
          no
          alco-val
          alco-type
          no-error }
            assign
               alco-val-log = logical(alco-val) no-error
               .
            if alco-val-log <> yes then 
            do:
               for each tt-attr-property where
                  tt-attr-property.table-name = {&table_goods-attr}
                  and tt-attr-property.attr-code = {&attr-alcohol-prod} :
                  assign
                     tt-attr-property.menu-item-handle:sensitive = no
                     .
               end.
            end.
         end.
      when {&table_gds-obj-attr} then 
         do:
           if not glog and glog-obj then do:
             disable
               b-list-obj
               with frame {&frame-name} .
               create obj-list .
               assign
               obj-list.obj-code = v-cntxt-obj-code
               obj-list.obj-type = v-cntxt-obj-type .
           end.
         end. /*{&table_gds-obj-attr}*/
      when {&table_gds-host-attr} then 
         do:
            assign
               b-list-obj:label in frame {&frame-name} = "Список фирм".
         end.
   END CASE.
   RUN proc-title IN THIS-PROCEDURE.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-add Dialog-Frame
PROCEDURE proc-b-add :
   define input parameter p-table as character no-undo.
   define variable attr-type           as character no-undo . /*тип атрибута*/
   define variable attr-format         as character no-undo .  /* формат атрибута*/
   define variable attr-label          as character no-undo .         /*лабел атрибута */
   DEFINE VARIABLE attr-range          as integer   no-undo .
   define variable attr-user-can-edit  as logical   no-undo .  /*пользователь может изменять в броусе*/
   define variable attr-output-display as logical   no-undo .  /*виден в броусе*/
   define variable attr-other          as char      no-undo .              /*еще чего - нибудь*/
   define var      loc#log             as logical   no-undo.
   define variable loc-action          as logical   no-undo.
   DEFINE VARIABLE jj                  as integer   no-undo .
   DEFINE VARIABLE v-spr               as character no-undo .
   DEFINE VARIABLE v-spr-param         as character no-undo .
   DEFINE VARIABLE v-add-option        as character no-undo .
   DEFINE VARIABLE v-deleted           as logical   no-undo .
   define buffer buf_temp-attr for temp-attr.
   do
      on error undo, return error
      :
      if add-option = "" then 
      do:
         run gbl/pop-up.p ( input self:handle, input no) no-error.
      end.
      if add-option = "":U then return error.
      assign
         v-add-option = add-option
         .
      run tempattr-exist in this-procedure (
         input add-option
         ,input add-host
         ,input add-obj-type
         ,input add-obj-code
         ,output loc#log
         ,output loc-action)  no-error.
      if error-status:error or loc#log then 
      do:
         if not error-status:error then
            message
               "Атрибут уже присутствует" skip
               string(if loc-action = yes
               then "в списке атрибутов, подлежащих установке/изменению"
               else "в списке атрибутов, подлежащих удалению"
               )
               view-as alert-box ERROR.
         undo, return error.
      end.
      CASE p-table:
         when {&table_gds-obj-attr} then 
            do:
               run gdsoattr-name in this-procedure (
                  input  add-option          /* p-code           */
                  ,output attr-type           /* p-type           */
                  ,output attr-format         /* p-format         */
                  ,output attr-label          /* p-label          */
                  ,output attr-user-can-edit  /* p-user-can-edit  */
                  ,output attr-output-display /* p-output-display */
                  ,output attr-other          /* p-other          */
                  ) no-error .
               if error-status :error then 
               do:
                  undo, return error .
               end.
            end.
         when {&table_gds-host-attr} then 
            do:
               run gdshattr-name in this-procedure (
                  input  add-option          /* p-code           */
                  ,output attr-type           /* p-type           */
                  ,output attr-format         /* p-format         */
                  ,output attr-label          /* p-label          */
                  ,output attr-user-can-edit  /* p-user-can-edit  */
                  ,output attr-output-display /* p-output-display */
                  ,output attr-other          /* p-other          */
                  ) no-error .
               if error-status :error then 
               do:
                  undo, return error.
               end.
            end.
         when {&table_clients-attr} then 
            do:
               run clntattr-code in this-procedure (
                  input  add-option          /* p-code           */
                  ,output attr-type           /* p-type           */
                  ,output attr-format         /* p-format         */
                  ,output attr-label          /* p-label          */
                  ,output attr-user-can-edit  /* p-user-can-edit  */
                  ,output attr-output-display /* p-output-display */
                  ,output attr-other          /* p-other          */
                  ) no-error .
               if error-status :error then 
               do:
                  return no-apply .
               end.
            end.
         when {&table_goods-attr} then 
            do:
               run gds-attr-name in this-procedure (
                  input  add-option          /* p-code           */
                  ,output attr-type           /* p-type           */
                  ,output attr-format         /* p-format         */
                  ,output attr-label          /* p-label          */
                  ,output attr-user-can-edit  /* p-user-can-edit  */
                  ,output attr-output-display /* p-output-display */
                  ,output attr-other          /* p-other          */
                  ) no-error .
               if error-status :error then 
               do:
                  undo, return error .
               end.
            end.
      END CASE.
      run tempattr-write in this-procedure (
         input yes /*p-add*/
         ,input add-option
         ,input add-host
         ,input add-obj-type
         ,input add-obj-code
         ,input (if attr-type = {&type-log}
         then "yes":U
         else
         (
         if attr-type = {&type-date}
         then ?
         else string(0)
         )
         )
         ,input yes
         ) no-error .

      IF ERROR-STATUS:ERROR THEN 
      DO:
         {&tempattr-type-get-error}
         undo,  return error.
      END.
      updated = yes.
      find first buf_temp-attr no-lock where
         buf_temp-attr.attr-code = add-option no-error.
      if avail buf_temp-attr then
         temp-doc-rec = recid(buf_temp-attr).
      else temp-doc-rec = ?.
      Run init-proc in this-procedure no-error.
      if error-status:error then 
      do:
         undo, return error.
      end.
      REPOSITION br-add to recid temp-doc-rec no-error.
      run proc-b-chg in this-procedure ( input "":U) no-error.
      if error-status:error then 
      do:
         run tempattr-delete in this-procedure (
            input v-add-option
            ,input 0
            ,input "":U
            ,input 0
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
   define input parameter p-table as character no-undo.
   define variable attr-type           as character no-undo . /*тип атрибута*/
   define variable attr-format         as character no-undo .  /* формат атрибута*/
   define variable attr-label          as character no-undo .         /*лабел атрибута */
   define variable attr-user-can-edit  as logical   no-undo .  /*пользователь может изменять в броусе*/
   define variable attr-output-display as logical   no-undo .  /*виден в броусе*/
   define variable attr-other          as char      no-undo .              /*еще чего - нибудь*/
   define variable loc#log             as logical   no-undo.
   define variable loc-action          as logical   no-undo.
   define buffer buf_temp-attr for temp-attr.
   DEFINE VARIABLE attr-range as integer no-undo .
   
   if add-option = "" then 
   do:
      run gbl/pop-up.p ( input self:handle, input no) no-error.
   end.
   CASE par-subject :
      WHEN {&table_clients-attr} THEN 
         DO:
            run tempattr-exist in this-procedure (
               input add-option
               ,input 0
               ,input "":U
               ,input 0
               ,output loc#log
               ,output loc-action)  no-error.
            if error-status:error or loc#log then 
            do:
               if not error-status:error then
                  message
                     "Атрибут уже присутствует" skip
                     string(if loc-action = yes
                     then "в списке атрибутов, подлежащих установке/изменению"
                     else "в списке атрибутов, подлежащих удалению"
                     )
                     view-as alert-box ERROR.
               return error.
            end.
            run clntattr-code in this-procedure (
               input  add-option          /* p-code           */
               ,output attr-type           /* p-type           */
               ,output attr-format         /* p-format         */
               ,output attr-label          /* p-label          */
               ,output attr-user-can-edit  /* p-user-can-edit  */
               ,output attr-output-display /* p-output-display */
               ,output attr-other          /* p-other          */
               ) no-error .
            run tempattr-write in this-procedure (
               input yes /*p-add*/
               ,input add-option
               ,input 0
               ,input "":U
               ,input 0
               ,input (if attr-type = {&type-log}
               then "yes":U
               else
               (
               if attr-type = {&type-date}
               then ?
               else string(0)
               )
               )
               ,input no
               ) no-error .
            IF ERROR-STATUS:ERROR THEN 
            DO:
               {&cliattr-type-get-error}
               return error.
            END.
         END.
      WHEN {&TABLE_gds-host-attr} THEN 
         DO:
            run tempattr-exist in this-procedure (
               input add-option
               ,input 0
               ,input "":U
               ,input 0
               ,output loc#log
               ,output loc-action)  no-error.
            if error-status:error or loc#log then 
            do:
               if not error-status:error then
                  message
                     "Атрибут уже присутствует" skip
                     string(if loc-action = yes
                     then "в списке атрибутов, подлежащих установке/изменению"
                     else "в списке атрибутов, подлежащих удалению"
                     )
                     view-as alert-box ERROR.
               return error.
            end.
            run gdshattr-name in this-procedure (
               input  add-option          /* p-code           */
               ,output attr-type           /* p-type           */
               ,output attr-format         /* p-format         */
               ,output attr-label          /* p-label          */
               ,output attr-user-can-edit  /* p-user-can-edit  */
               ,output attr-output-display /* p-output-display */
               ,output attr-other          /* p-other          */
               ) no-error .
            if error-status :error then 
            do:
               return error .
            end.
            run tempattr-write in this-procedure (
               input yes /*p-add*/
               ,input add-option
               ,input 0
               ,input "":U
               ,input 0
               ,input (if attr-type = {&type-log}
               then "yes":U
               else
               (
               if attr-type = {&type-date}
               then ?
               else string(0)
               )
               )
               ,input no
               )  no-error.
            IF ERROR-STATUS:ERROR THEN 
            DO:
               {&tempattr-type-get-error}
               return error.
            END.
         END.
      WHEN {&TABLE_goods-attr} THEN 
         DO:
            run tempattr-exist in this-procedure(
               input add-option
               ,input 0
               ,input "":U
               ,input 0
               ,output loc#log
               ,output loc-action)  no-error.
            if error-status:error or loc#log then 
            do:
               if not error-status:error then
                  message
                     "Атрибут уже присутствует" skip
                     string(if loc-action = yes
                     then "в списке атрибутов, подлежащих установке/изменению"
                     else "в списке атрибутов, подлежащих удалению"
                     )
                     view-as alert-box ERROR.
               return error.
            end.
            run gds-attr-name in this-procedure (
               input  add-option          /* p-code           */
               ,output attr-type           /* p-type           */
               ,output attr-format         /* p-format         */
               ,output attr-label          /* p-label          */
               ,output attr-user-can-edit  /* p-user-can-edit  */
               ,output attr-output-display /* p-output-display */
               ,output attr-other          /* p-other          */
               ) no-error .
            if error-status :error then 
            do:
               return error .
            end.
            run tempattr-write in this-procedure(
               input yes /*p-add*/
               ,input add-option
               ,input 0
               ,input "":U
               ,input 0
               ,input (if attr-type = {&type-log}
               then "yes":U
               else
               (
               if attr-type = {&type-date}
               then ?
               else string(0)
               )
               )
               ,input no
               )  no-error.
            IF ERROR-STATUS:ERROR THEN 
            DO:
               {&tempattr-type-get-error}
               return error.
            END.
         END.
      WHEN {&table_gds-obj-attr} THEN 
         DO:
            run tempattr-exist in this-procedure (
               input add-option
               ,input 0
               ,input "":U
               ,input 0
               ,output loc#log
               ,output loc-action)  no-error.
            if error-status:error or loc#log then 
            do:
               if not error-status:error then
                  message
                     "Атрибут уже присутствует" skip
                     string(if loc-action = yes
                     then "в списке атрибутов, подлежащих установке/изменению"
                     else "в списке атрибутов, подлежащих удалению"
                     )
                     view-as alert-box ERROR.
               return error.
            end.
            run gdsoattr-name in this-procedure (
               input  add-option          /* p-code           */
               ,output attr-type           /* p-type           */
               ,output attr-format         /* p-format         */
               ,output attr-label          /* p-label          */
               ,output attr-user-can-edit  /* p-user-can-edit  */
               ,output attr-output-display /* p-output-display */
               ,output attr-other          /* p-other          */
               ) no-error .
            if error-status :error then 
            do:
               return error .
            end.
            run tempattr-write in this-procedure (
               input yes /*p-add*/
               ,input add-option
               ,input 0
               ,input "":U
               ,input 0
               ,input (if attr-type = {&type-log}
               then "yes":U
               else
               (
               if attr-type = {&type-date}
               then ?
               else string(0)
               )
               )
               ,input no
               )  no-error.
            IF ERROR-STATUS:ERROR THEN 
            DO:
               {&tempattr-type-get-error}
               return error.
            END.
         END.
   END CASE.
   updated = yes.
   find first buf_temp-attr no-lock where
      buf_temp-attr.attr-code = add-option
      AND buf_temp-attr.HOST-CODE = add-HOST
      and buf_temp-attr.OBJ-TYPE = add-OBJ-TYPE
      and buf_temp-attr.OBJ-CODE = add-OBJ-CODE  no-error.
   if avail buf_temp-attr then
      temp-doc-rec = recid(buf_temp-attr).
   else temp-doc-rec = ?.
   Run init-proc in this-procedure .
   reposition BR-del to recid temp-doc-rec no-error.
   if error-status:error then return error.
   APPLY "ENTRY" to br-del in frame {&frame-name} .
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-chg Dialog-Frame
PROCEDURE proc-b-chg :
   /*------------------------------------------------------------------------------
     Purpose:
     Parameters:  <none>
     Notes:
   ------------------------------------------------------------------------------*/
   define input parameter p-mode as character no-undo .
   define variable attr-value          as character no-undo . /*значение атрибута*/
   define variable attr-type           as character no-undo . /*тип атрибута*/
   define variable attr-format         as character no-undo .  /* формат атрибута*/
   define variable attr-label          as character no-undo .         /*лабел атрибута */
   DEFINE VARIABLE attr-range          as integer   no-undo .
   define variable attr-user-can-edit  as logical   no-undo .  /*пользователь может изменять в броусе*/
   define variable attr-output-display as logical   no-undo .  /*виден в броусе*/
   define variable attr-other          as char      no-undo .              /*еще чего - нибудь*/
   DEFINE VARIABLE jj                  as integer   no-undo .
   DEFINE VARIABLE v-spr               as character no-undo .
   DEFINE VARIABLE v-spr-ext           as character no-undo .
   DEFINE VARIABLE v-spr-param         as character no-undo .
   define variable v-setted            as logical   no-undo .
   define variable v-check             as character no-undo .
   define variable v-attr-entry        as character no-undo .
   if not avail temp-attr then return error.
   CASE par-subject:
      when {&table_gds-obj-attr} then 
         do:
            run gdsoattr-name in this-procedure (
               input  TEMP-attr.attr-code           /* p-code           */
               ,output attr-type
               ,output attr-format
               ,output attr-label
               ,output attr-user-can-edit
               ,output attr-output-display
               ,output attr-other
               ) no-error .
         end.
      when {&table_gds-host-attr} then 
         do:
            run gdshattr-name in this-procedure (
               input  TEMP-attr.attr-code           /* p-code           */
               ,output attr-type
               ,output attr-format
               ,output attr-label
               ,output attr-user-can-edit
               ,output attr-output-display
               ,output attr-other
               ) no-error .
         end.
      when {&table_clients-attr} then 
         do:
            run clntattr-code in this-procedure (
               input TEMP-attr.attr-code
               ,output attr-type
               ,output attr-format
               ,output attr-label
               ,output attr-user-can-edit
               ,output attr-output-display
               ,output attr-other
               ) no-error.
         end.
      WHEN {&table_goods-attr} THEN 
         DO:
            run gds-attr-name in this-procedure (
               input  TEMP-attr.attr-code           /* p-code           */
               ,output attr-type
               ,output attr-format
               ,output attr-label
               ,output attr-user-can-edit
               ,output attr-output-display
               ,output attr-other
               ) no-error .

         END.
   END CASE.
   IF ERROR-STATUS:ERROR THEN 
   DO:
      {&tempattr-type-get-error}
      return error.
   END.
   RUN tempATTR-VALUE IN THIS-PROCEDURE (
      input TEMP-attr.attr-code
      ,input temp-attr.host-code
      ,input temp-attr.obj-type
      ,input temp-attr.obj-code
      ,input p-mode
      ,OUTPUT ATTR-VALUE
      ,OUTPUT attr-type) NO-ERROR.
   IF ERROR-STATUS:ERROR THEN 
   DO:
      if return-value <> "not-set":U then 
      do:
         {&tempattr-value-get-error}
      end.
      RETURN error.
   END.
   if return-value = "not-set":U
      and p-mode <> "change":U then 
   do:
      delete temp-attr.
      glog = br-add:refresh() in frame {&frame-name} no-error .
      return .
   end.
   IF attr-user-can-edit Then 
   DO:
      do jj = 1 to num-entries(attr-other, {&slash-char}):
         v-attr-entry = entry(jj, attr-other, {&slash-char}) .
         if entry(1, v-attr-entry, "=":U) = "spr":U then 
         do:
            assign
               v-spr = string(entry(2, v-attr-entry, "=":U))
               .
         end.
         if entry(1, v-attr-entry, "=":U) = "spr-ext":U then 
         do:
            assign
               v-spr-ext = entry(2, v-attr-entry, "=":U)
               .
         end.  
         if entry(1, v-attr-entry, "=":U) = "spr-param":U then 
         do:
            assign
               v-spr-param = entry(2, v-attr-entry, "=":U)
               .
         end.       
      end.
      if v-spr = "":U and v-spr-ext = "" then 
      do:
         run gbl/d-prompt.w (
            'title=':u + "Изменение атрибута" + '\':u
            + 'text1=':u + attr-label + '\':u
            + 'format=' + (if attr-type = {&type-log} then "yes/no" else attr-format) + '\':u
            + 'type=' + attr-type + '\':u
            + 'fillin_row=2\':u
            + 'fillin_col=4\':u
            + 'fillin_width=20\':u
            + 'fillin_height=1\':u
            + 'max-chars=70\':u     /*- максимальное количество символов для редактора*/
            + 'readonly=no' + '\':u
            , input-output attr-value
            ).
         if return-value = 'false':u then return error.
      end.
      else 
      do:
         attr-value = "" .
         if v-spr = '':u then 
         do:
            if v-spr-param = "":U then 
            do:
               run  value(v-spr-ext)  (
                  input ({&add-def})
                  ,input 0
                  ,input-output attr-value
                  ,output v-setted) no-error .

            end.
            else 
            do:
               run  value(v-spr-ext) (
                  input ({&add-def})
                  ,input 0
                  ,input v-spr-param
                  ,input-output attr-value
                  ,output v-setted) no-error .
            end.
            if not v-setted then return error.

         end.
         if v-spr-ext = '':U then 
         do:
            if v-spr-param = "":U then 
            do:
               run  value(v-spr) in this-procedure (
                  input 0
                  ,input-output attr-value
                  ,output v-setted) no-error .

            end.
            else 
            do:
               run  value(v-spr) in this-procedure (
                  input 0
                  ,input v-spr-param
                  ,input-output attr-value
                  ,output v-setted) no-error .
            end.
            if not v-setted then return error.
         end.
      end.    
      run tempattr-write (
         input no /*p-add*/
         ,input temp-attr.attr-code
         ,input temp-attr.host-code
         ,input temp-attr.obj-type
         ,input temp-attr.obj-code
         ,input attr-value
         ,input temp-attr.action) no-error.
      IF not error-status:error then 
      do:
         assign
            updated = yes
            .
      END.
      glog = br-add:refresh() in frame {&frame-name} no-error .
   End.
   Else
      message "Изменение атрибута невозможно !"
         view-as alert-box error.
   APPLY "ENTRY" to br-add.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-b-exit Dialog-Frame
PROCEDURE proc-b-exit :
   define variable loc#log      as logical no-undo .
   define variable v-not-all-ok as logical no-undo .
   define variable v-num-list   as integer no-undo .
   define variable v-delete-ok  as logical no-undo .

   if not can-find(first temp-attr) then 
   do:
      message "Вы не определили список атрибутов для изменения (добавления, удаления)"
         view-as alert-box.
      return no-apply.
   end.
   if t-delete-ok:visible in frame {&frame-name} then
      ASSIGN
         FRAME {&FRAME-NAME} t-delete-ok.
   assign
      v-delete-ok = t-delete-ok.
   CASE par-subject:
      when {&table_gds-obj-attr} then 
         do:
            if not can-find(first gds-list) then 
            do:
               message "Вы не определили список товаров"
                  view-as alert-box.
               return no-apply.
            end.
            if not can-find(first obj-list) then 
            do:
               message "Вы не определили список объектов"
                  view-as alert-box.
               return no-apply.
            end.
            message
               "Вы уверены, что Вы хотите провести изменение (добавление, удаление) атрибутов товара на объекте" SKIP
               "по всему определенному Вами списку?"
               view-as alert-box QUESTION buttons YES-NO update loc#log.
            for each obj-list :
               v-num-list = v-num-list + 1.
               if v-num-list > 1 then leave.
            end.
            if loc#log then 
            do:
               run str/diallog.w (
                  input parparentproc
                  , input this-procedure
                  , input "ref/goatrlst.p":U
                  , input (string(parhost-code) + {&delim-par} + parobj-type + {&delim-par} + string(parobj-code) + {&delim-par} + string(v-delete-ok))
                  , input no /*p-auto-go*/
                  , input "&Стоп":U
                  , input substitute("Изменение атрибутов товаров по списку товаров"
                  )
                  ) no-error.
               assign
                  v-not-all-ok = can-find(first gds-list) AND v-num-list = 1.
            end.
         end.
      when {&table_gds-host-attr} then 
         do:
            if not can-find(first gds-list) then 
            do:
               message "Вы не определили список товаров"
                  view-as alert-box.
               return no-apply.
            end.
            if not can-find(first obj-list) then 
            do:
               message "Вы не определили список фирм"
                  view-as alert-box.
               return no-apply.
            end.
            message
               "Вы уверены, что Вы хотите провести изменение (добавление, удаление) атрибутов товара на фирме" SKIP
               "по всему определенному Вами списку?"
               view-as alert-box QUESTION buttons YES-NO update loc#log.
            for each obj-list
               :
               v-num-list = v-num-list + 1.
               if v-num-list > 1 then leave.
            end.
            if loc#log then 
            do:
               run str/diallog.w (
                  input parparentproc
                  , input this-procedure
                  , input "ref/ghatrlst.p":U
                  , input (string(parhost-code) + {&delim-par} + parobj-type + {&delim-par} + string(parobj-code) + {&delim-par} + string(v-delete-ok))
                  , input no /*p-auto-go*/
                  , input "&Стоп":U
                  , input substitute("Изменение атрибутов товаров на фирме по списку товаров"

                  )
                  ) no-error.
               assign
                  v-not-all-ok = can-find(first gds-list) AND v-num-list = 1.
            end.
         end.
      when {&table_clients-attr} then 
         do:
            if not can-find(first cli-list) then 
            do:
               message "Вы не определили список клиентов"
                  view-as alert-box.
               return no-apply.
            end.
            message
               "Вы уверены, что Вы хотите провести изменение (добавление, удаление) атрибутов клиентов" SKIP
               "по всему определенному Вами списку?"
               view-as alert-box QUESTION buttons YES-NO update loc#log.
            if loc#log then 
            do:
               run str/diallog.w (
                  input parparentproc
                  , input this-procedure
                  , input "ref/clatrlst.p":U
                  , input (string(parhost-code) + {&delim-par} + parobj-type + {&delim-par} + string(parobj-code) + {&delim-par} + string(v-delete-ok))
                  , input no /*p-auto-go*/
                  , input "&Стоп":U
                  , input substitute("Изменение атрибутов клиентов по списку клиентов"
                  )
                  ) no-error.
               assign
                  v-not-all-ok = can-find(first cli-list).
            end.
         end.
      WHEN {&table_goods-attr} THEN 
         DO:
            if not can-find(first gds-list) then 
            do:
               message "Вы не определили список товаров"
                  view-as alert-box.
               return no-apply.
            end.
            message
               "Вы уверены, что Вы хотите провести изменение (добавление, удаление) глобальных атрибутов товара" SKIP
               "по всему определенному Вами списку?"
               view-as alert-box QUESTION buttons YES-NO update loc#log.
            if loc#log then 
            do:
               run str/diallog.w (
                  input parparentproc
                  , input this-procedure
                  , input "ref/g-atrlst.p":U
                  , input (string(parhost-code) + {&delim-par} + parobj-type + {&delim-par} + string(parobj-code) + {&delim-par} + string(v-delete-ok))
                  , input no /*p-auto-go*/
                  , input "&Стоп":U
                  , input substitute("Изменение глобальных атрибутов товара по списку товаров"
                  , parobj-type
                  , parobj-code
                  )
                  ) no-error.
               assign
                  v-not-all-ok = can-find(first gds-list).
            end.
         END.
   END CASE.
   if v-not-all-ok and v-delete-ok then 
   do:
      assign
         b-list:width = 30
         b-list:label = "Список неизменившихся".
   end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-title Dialog-Frame
PROCEDURE proc-title :
   /*------------------------------------------------------------------------------
     Purpose:
     Parameters:  <none>
     Notes:
   ------------------------------------------------------------------------------*/
   CASE par-subject:
      WHEN {&table_gds-obj-attr} THEN 
         DO:
            frame {&frame-name}:title = substitute("Изменение атрибутов товара на объекте по списку товаров") .
            assign
               v-tab-order = "b-exit,b-quit,b-list,b-list-obj,b-help,T-delete-ok,b-add,b-add-2".
         END.
      WHEN {&table_gds-host-attr} THEN 
         DO:
            frame {&frame-name}:title = substitute("Изменение атрибутов товара на фирме по списку товаров"
               ,parhost-code).
            assign
               v-tab-order = "b-exit,b-quit,b-list,b-list-obj,b-help,T-delete-ok,b-add,b-add-2".
         END.
      when {&table_clients-attr} then 
         do:
            frame {&frame-name}:title = "Изменение атрибутов клиента по списку клиентов".
            assign
               v-tab-order  = "b-exit,b-quit,b-list,b-help,T-delete-ok,b-add,b-add-2"
               b-list:label = "Список клиентов".
         end.
      WHEN {&table_goods-attr} THEN 
         DO:
            frame {&frame-name}:title = substitute("Изменение глобальных атрибутов товара по списку товаров") .
            assign
               v-tab-order = "b-exit,b-quit,b-list,b-help,T-delete-ok,b-add,b-add-2".
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